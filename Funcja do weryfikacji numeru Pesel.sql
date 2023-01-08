--Tytuł: Funkcja do weryfikacji poprawności numeru PESEL
--Autor: Adam Bernaś
--Update: 08-01-2022
--Wersja: 1.3
--Opis: 
--Funkcja weryfikuje PESEL pod względem poprawności poprzez sprawdzenie cyfry kontrolnej metodą określoną w rozporządzeniu Ministra Spraw Wewnętrznych.
--Dodatkowo funkcja oddaje informacje zwrotną w przypadku zweryfikowania numeru jako NIP lub w sytuacji gdy wskazany numer nie odpowiada do schematu numeru pesel i wskazuje jakie wykryła błędy.

-- Skrót do obsługi Funkcji
-- SELECT dbo.PESEL_Weryfikacja('tu wprowadź numer PESEL')

IF OBJECT_ID('PESEL_Weryfikacja') IS NOT NULL DROP FUNCTION dbo.PESEL_Weryfikacja
GO
CREATE FUNCTION dbo.PESEL_Weryfikacja (@Numer VARCHAR(255))
RETURNS VARCHAR(255)
AS
BEGIN
		DECLARE @idType VARCHAR(255) = 'Nieznany'
	BEGIN
		IF @Numer IS NULL OR @Numer = '' OR @Numer = ' '
		BEGIN
			SET @idType = 'Brak numeru'
		END
		-- Sprawdź, czy numer ma 11 cyfr
	ELSE IF LEN(@Numer) = 11
		BEGIN
			-- Sprawdź, czy numer składa się z samych cyfr
			DECLARE @peselPattern VARCHAR(255) = '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
			IF @Numer LIKE @peselPattern
				SET @idType = 'PESEL'
			ELSE 
				SET @idType = 'Błąd w numerze PESEL: zawiera niedozwolony znak'
		END
	ELSE IF LEN(@Numer) = 10
		BEGIN
			-- Sprawdź, czy numer składa się z samych cyfr
			DECLARE @nipPattern VARCHAR(255) = '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
			IF @Numer LIKE @nipPattern
				SET @idType = 'NIP'
			ELSE 
				SET @idType = 'Błąd w numerze NIP: zawiera niedozwolony znak'
		END
	END
	DECLARE @pesel VARCHAR(255) = @Numer
	DECLARE @Opis Nvarchar(500) = ''
	-- Sprawdź, czy numer to pesel
	IF @idType <> 'PESEL'
	BEGIN
		IF @Numer IS NULL OR @Numer = '' OR @Numer = ' '
		SET @Opis = @idType
		ELSE IF ((LEN(@Numer) < 10) AND (@Numer IS NOT NULL OR @Numer <> '' OR @Numer <> ' '))
			SET @Opis = 'Typ: '+ @idType + '.' + char(10) + 'Liczba znaków < 10'
		ELSE IF LEN(@Numer) > 11
			SET @Opis = 'Typ: '+ @idType + '.' + char(10) +  'Liczba znaków > 11'
		ELSE IF @idType = 'NIP'
			SET @Opis = 'Typ: '+ @idType
		ELSE IF LEN(@Numer) = 11
			SET @Opis = @idType
		ELSE IF LEN(@Numer) = 10
			SET @Opis = @idType
			RETURN @Opis
	END
	-- Sprawdz czy podany numer pesel jest prawidłowy
	-- Oblicz sumę kontrolną
	DECLARE @sum INT =
		(1 * SUBSTRING(@pesel, 1, 1)) +
		(3 * SUBSTRING(@pesel, 2, 1)) +
		(7 * SUBSTRING(@pesel, 3, 1)) +
		(9 * SUBSTRING(@pesel, 4, 1)) +
		(1 * SUBSTRING(@pesel, 5, 1)) +
		(3 * SUBSTRING(@pesel, 6, 1)) +
		(7 * SUBSTRING(@pesel, 7, 1)) +
		(9 * SUBSTRING(@pesel, 8, 1)) +
		(1 * SUBSTRING(@pesel, 9, 1)) +
		(3 * SUBSTRING(@pesel, 10, 1))
	--select @sum as [sum]
	-- Sprawdź, czy cyfra kontrolna jest poprawna
	DECLARE @controlDigit INT = 10 - (@sum % 10)
	--select @controlDigit as [controlDigit]
	IF @controlDigit = 10
		SET @controlDigit = 0
	IF SUBSTRING(@pesel, 11, 1) <> CAST(@controlDigit AS VARCHAR(255))
	BEGIN
		SET @Opis = 'Typ: ' + @idType + '.' + char(10) + 'Status: BŁĄD- Niepoprawna cyfra kontrolna'
		RETURN @Opis
	END
	ELSE
		SET @Opis = 'Typ: ' + @idType + '.' + char(10) + 'Status: POPRAWNY'
	RETURN @Opis
END
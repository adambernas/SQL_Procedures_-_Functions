--Tytuł: Funkcja do wyciągania daty urodzenia z numeru PESEL
--Autor: Adam Bernaś
--Update: 11-01-2023
--Wersja: 1.2
--Opis: Funkcja wyciąga date urodzenia na podstawie wskazanego numeru PESEL. Działa poprawnie w zakresie od 1800 do 2299 roku.

--Przykład obsługi funkcji
--SELECT dbo.ExtractBirthDateFromPESEL('Tutaj wprowadź numer PESEL')

IF OBJECT_ID('dbo.ExtractBirthDateFromPESEL') IS NOT NULL DROP FUNCTION dbo.extractBirthDateFromPESEL
GO
CREATE FUNCTION dbo.ExtractBirthDateFromPESEL 
(@pesel varchar(11))
RETURNS DATE
AS
BEGIN
    DECLARE 
	@year varchar(4) = SUBSTRING(@pesel, 1, 2),
	@month varchar(2) = SUBSTRING(@pesel, 3, 2), 
	@day varchar(2) = SUBSTRING(@pesel, 5, 2);

    -- warunki dla roku urodzenia 1800-1899
    IF (@month > 80)
		BEGIN
			SET @year = '18' + @year;
			SET @month = @month - 80;
		END
    -- warunki dla roku urodzenia 2200-2299
    ELSE IF (@month > 60)
		BEGIN
			SET @year = '22' + @year;
			SET @month = @month - 60;
		END
    -- warunki dla roku urodzenia 2100-2199
    ELSE IF (@month > 40)
		BEGIN
			SET @year = '21' + @year;
			SET @month = @month - 40;
		END
    -- warunki dla roku urodzenia 2000-2099
    ELSE IF (@month > 20)
		BEGIN
			SET @year = '20' + @year;
			SET @month = @month - 20;
		END
    -- warunki dla roku urodzenia 1900-1999
    ELSE
		BEGIN
			SET @year = '19' + @year;
		END

    RETURN DATEFROMPARTS(@year, @month, @day)
END;

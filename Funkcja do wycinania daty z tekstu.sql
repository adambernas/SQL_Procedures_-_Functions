--Tytuł: Funkcja do wycinana daty z tekstu
--Autor: Adam Bernaś
--Update: 10-01-2023
--Wersja: 1.2
--Opis: 
--Funkcja wycina datę z wskazanego tekstu według 4 schematów. W przypadku błędu kalendarzowego daty np 31 luty wkaże informację o błędzie.

--Przykłady do obsługi funkcji:
--SELECT dbo.GetDateFromText('Przykładowy tekst, 31-02-2001')
--SELECT dbo.GetDateFromText('Przykładowy tekst, 2001-02-21')
--SELECT dbo.GetDateFromText('Przykładowy tekst, 20010221')
--SELECT dbo.GetDateFromText('Przykładowy tekst, 01022021')

IF OBJECT_ID('GetDateFromText') IS NOT NULL DROP FUNCTION dbo.GetDateFromText
GO
CREATE FUNCTION dbo.GetDateFromText 
(@text nvarchar(max)) 
RETURNS nvarchar(max) AS
BEGIN
	DECLARE @checkdate nvarchar(20) = NULL
	DECLARE @date nvarchar(20) = NULL
	-- Szukaj wzorca daty w formacie DD-MM-YYYY
	DECLARE @pattern1 nvarchar(max)
	SET @pattern1 = '%[0-3][0-9]-[0-1][0-9]-[0-9][0-9][0-9][0-9]%'
	-- Szukaj wzorca daty w formacie YYYY-MM-DD
  	DECLARE @pattern2 nvarchar(max)
	SET @pattern2 = '%[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]%'
	-- Szukaj wzorca daty w formacie YYYYMMDD
  	DECLARE @pattern3 nvarchar(max)
	SET @pattern3 = '%[0-9][0-9][0-9][0-9][0-1][0-9][0-3][0-9]%'
	-- Szukaj wzorca daty w formacie DDMMYYYY
  	DECLARE @pattern4 nvarchar(max)
	SET @pattern4 = '%[0-3][0-9][0-1][0-9][0-9][0-9][0-9][0-9]%'

		DECLARE @start int
	-- Szukaj indeks początku 1 wzorca w tekście		
		SET @start = PATINDEX(@pattern1, @text)
	-- Jeśli PATINDEX zwrócił coś innego niż 0, to oznacza, że znaleziono wzorzec
		IF @start > 0
		BEGIN
	-- Pobierz datę
		SET @checkdate = LTRIM(RTRIM(SUBSTRING(@text, @start, 10)))

		DECLARE @day nvarchar(2) = LEFT(@checkdate, 2)
		DECLARE @month nvarchar(2) = SUBSTRING(@checkdate, 4, 2)
		DECLARE @year nvarchar(4) = RIGHT(@checkdate, 4)
		SET @checkdate = @year + @month + @day
		END
	-- Jeli @pattern1 nie pasuje szukaj dalej
		IF @start = 0
		BEGIN
	-- Szukaj indeks początku 2 wzorca w tekście
		SET @start = PATINDEX(@pattern2, @text)
		IF @start > 0
	-- Pobierz datę
		SET @checkdate = LTRIM(RTRIM(SUBSTRING(@text, @start, 10)))
		END
	-- Jeli @pattern2 nie pasuje szukaj dalej
		IF @start = 0
		BEGIN
	-- Szukaj indeks początku 3 wzorca w tekście
		SET @start = PATINDEX(@pattern3, @text)
		IF @start > 0
	-- Pobierz datę
		SET @checkdate = LTRIM(RTRIM(SUBSTRING(@text, @start, 8)))
		END
	-- Jeli @pattern3 nie pasuje szukaj dalej
		IF @start = 0
		BEGIN
	-- Szukaj indeks początku 4 wzorca w tekście
		SET @start = PATINDEX(@pattern4, @text)
		IF @start > 0
	-- Pobierz datę
		SET @checkdate = LTRIM(RTRIM(SUBSTRING(@text, @start, 8)))

		DECLARE @day2 nvarchar(2) = LEFT(@checkdate, 2)
		DECLARE @month2 nvarchar(2) = SUBSTRING(@checkdate, 3, 2)
		DECLARE @year2 nvarchar(4) = RIGHT(@checkdate, 4)
		SET @checkdate = @year2 + @month2 + @day2
		END
	-- Jeżeli nie wykryto daty dla żadnego schematu
		ELSE
		SET @date = 'Brak daty w tekscie'
		
	-- Sprawdz poprawność daty
	IF ISDATE(@checkdate) = 1
		SET @date = CAST(@checkdate as DATE)
	ELSE
		SET @date = 'Błędna data'

  RETURN @date
END
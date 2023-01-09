--Tytuł: Funkcja do wycinana tekstu po wskazanym znaku
--Autor: Adam Bernaś
--Update: 09-01-2023
--Wersja: 1.2
--Opis: 
--Funkcja wycina test od wskazanego znaku do końca lub od potórzenia wskazanego znaku do końca 

-- Przykład do obsługi funkcji
-- SELECT dbo.CutTextFromChar('Przykładowy, test, do, wycinania, przecinka', ',' , 2)

IF OBJECT_ID('dbo.CutTextFromChar') IS NOT NULL DROP FUNCTION dbo.CutTextFromChar
GO
CREATE FUNCTION dbo.CutTextFromChar
 --Zmienne
(@text nvarchar(max),
 @char nvarchar(50),
 @wystapienie int)

RETURNS NVARCHAR(MAX) AS

BEGIN
  DECLARE @result nvarchar(max) = NULL
  DECLARE @index int = 0

--Obsługa błędów
IF (@text IS NULL OR @text= '' OR @text = ' ')
	BEGIN
	SET @result = 'BŁĄD: Brak wskazanego tekstu'
	RETURN @result
	END

IF @char IS NULL
	BEGIN
	SET @result = 'BŁĄD: Brak wskazanego separatora'
	RETURN @result
	END

IF (@wystapienie is NULL OR @wystapienie= 0)
	BEGIN
	SET @result = 'BŁĄD: Brak wskazania wystąpienia separatora'
	RETURN @result
	END

  --Szukamy indeksu odpowiedniego dla wystąpienia znaku
  WHILE @wystapienie > 0 AND @index < LEN(@text) 
	  BEGIN
		SET @index = CHARINDEX(@char, @text, @index + 1)
		SET @wystapienie = @wystapienie - 1
	  END
  
  --Jeśli znak został znaleziony, to wycinamy tekst od wskazanego miejsca +1
  IF @index > 0 BEGIN
    SET @result = LTRIM(RTRIM(SUBSTRING(@text, @index +1, LEN(@text))))
  END

	RETURN @result
END
-- FUN��ES, TRIGGERS E STORED PROCEDURES

-- Esta fun��o cria um c�digo �nico atrav�s da concatena��o de uma letra com o timestamp.
-- O c�digo gerado � utilizado para inserir na tabela Criador
CREATE FUNCTION PROJETO.getUniqueCode (@char VARCHAR(2))
RETURNS VARCHAR(15)
AS
BEGIN
    DECLARE @time VARCHAR(15), @code VARCHAR(15)
    SELECT @time = CAST(DATEDIFF_BIG(MILLISECOND, '1970-01-01', GETDATE()) AS VARCHAR(15));
    SET @code = CONCAT(@char, @time)
    RETURN @code
END

-- Antes de inserirmos uma entidade capaz de criar um ficheiro, temos de lhe associar uma entidade criador
-- Este trigger utiliza a fun��o getUniqueCode para criar um Criador e s� depois insere os valores na tabela Grupo
CREATE TRIGGER createCriadorGrupo
ON PROJETO.Grupo
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @code VARCHAR(15);
    DECLARE @nome VARCHAR(250), @cadeira INT;
    
	BEGIN TRANSACTION
		SELECT @code = PROJETO.getUniqueCode('G');

		INSERT INTO PROJETO.Criador VALUES(@code);

		SELECT @nome = nome, @cadeira = cadeira FROM INSERTED;

		INSERT INTO PROJETO.Grupo VALUES(@nome, @cadeira, @code);
	COMMIT

END

-- Antes de inserirmos uma entidade capaz de criar um ficheiro, temos de lhe associar uma entidade criador
-- Este trigger utiliza a fun��o getUniqueCode para criar um Criador e s� depois insere os valores na tabela Cadeira
CREATE TRIGGER createCriadorCadeira
ON PROJETO.Cadeira
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @code VARCHAR(15);
    DECLARE @nome VARCHAR(250), @link VARCHAR(250), @ano INT,
		@semestre INT, @nota_final FLOAT, @aluno VARCHAR(250), @instituicao INT;
	
	BEGIN TRANSACTION
		SELECT @code = PROJETO.getUniqueCode('C');

		INSERT INTO PROJETO.Criador VALUES(@code);

		SELECT @nome = nome, @link = link, @ano = ano, @semestre = semestre,
			@nota_final = nota_final, @aluno = aluno, @instituicao = instituicao
		FROM INSERTED;

		INSERT INTO PROJETO.Cadeira VALUES(@nome, @link, @ano, @semestre, @nota_final, @aluno, @code, @instituicao);
	COMMIT

END

-- Antes de inserirmos uma entidade capaz de criar um ficheiro, temos de lhe associar uma entidade criador
-- Este trigger utiliza a fun��o getUniqueCode para criar um Criador e s� depois insere os valores na tabela Tarefa
CREATE TRIGGER createCriadorTarefa
ON PROJETO.Tarefa
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @code VARCHAR(15);
    DECLARE @titulo VARCHAR(250), @descricao VARCHAR(250), @completada_ts DATETIME,
		@data_inicio DATE, @date_final DATE, @tipoTarefa INT, @aluno VARCHAR(250), @cadeira INT;
	
	BEGIN TRANSACTION
		SELECT @code = PROJETO.getUniqueCode('T');

		INSERT INTO PROJETO.Criador VALUES(@code);

		SELECT @titulo = titulo, @descricao = descricao, @completada_ts = completada_ts, @data_inicio = data_inicio,
			@date_final = date_final, @aluno = aluno, @tipoTarefa = tipoTarefa, @cadeira = cadeira
		FROM INSERTED;

		INSERT INTO PROJETO.Tarefa VALUES(@titulo, @descricao, @completada_ts, @data_inicio,
			@date_final, @tipoTarefa, @aluno, @cadeira, @code);
	COMMIT

END

-- Antes de inserirmos uma entidade capaz de criar um ficheiro, temos de lhe associar uma entidade criador
-- Este trigger utiliza a fun��o getUniqueCode para criar um Criador e s� depois insere os valores na tabela Pagina
CREATE TRIGGER createCriadorPagina
ON PROJETO.Pagina
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @code VARCHAR(15);
    DECLARE @titulo VARCHAR(250), @aluno VARCHAR(250), @cadeira INT;

	BEGIN TRANSACTION
		SELECT @code = PROJETO.getUniqueCode('P');

		INSERT INTO PROJETO.Criador VALUES(@code);

		SELECT @titulo = titulo, @aluno = aluno, @cadeira = cadeira
		FROM INSERTED;

		INSERT INTO PROJETO.Pagina VALUES(@titulo, @aluno, @cadeira, @code);
	COMMIT

END

-- #### DELETE ####

-- N�o queremos permitir que as contas sejam eliminadas, em vez disso ficam disabled
CREATE TRIGGER deleteAluno
ON PROJETO.Aluno
INSTEAD OF DELETE
AS
BEGIN
	DECLARE @email VARCHAR(250);

	BEGIN TRANSACTION
		SELECT @email = email FROM DELETED;

		UPDATE PROJETO.Aluno SET disabled = 1 WHERE email = @email;
	COMMIT

END
select * from PROJETO.Aluno
delete from PROJETO.Aluno where email = 'admin@sapo.pt'

-- Ver se podemos eliminar ou se h� depend�ncias
CREATE TRIGGER deletePagina
ON PROJETO.Pagina
INSTEAD OF DELETE
AS
BEGIN
	-- Basicamente se n�o existir no PaginaGrupo pode eliminar, porque n�o h� nenhuma depend�ncia

	DECLARE @n INT, @id INT;

	SELECT @id = id FROM DELETED;

	SELECT @n = COUNT(*) FROM PROJETO.PaginaGrupo WHERE pagina = @id;

	IF @n > 0
		BEGIN
			UPDATE PROJETO.Pagina SET disabled = 1 WHERE id = @id;
		END
	ELSE
		-- N�o h� depend�ncias
		BEGIN
			BEGIN TRANSACTION
				DECLARE @code VARCHAR(20);
				SELECT @code = codigo_criador FROM DELETED;

				DELETE FROM PROJETO.Ficheiro WHERE codigo_criador = @code;
				DELETE FROM PROJETO.Criador WHERE codigo = @code;
				DELETE FROM PROJETO.Pagina WHERE id = @id;
			COMMIT
		END
END

-- Ver se podemos eliminar ou se h� depend�ncias
CREATE TRIGGER deleteTarefa
ON PROJETO.Tarefa
INSTEAD OF DELETE
AS
BEGIN
	-- Basicamente se n�o existir no TarefaGrupo pode eliminar, porque n�o h� nenhuma depend�ncia

	DECLARE @n INT, @id INT;
	SELECT @id = id FROM DELETED;

	SELECT @n = COUNT(*) FROM PROJETO.TarefaGrupo WHERE tarefa = @id;

	IF @n > 0
		BEGIN
			UPDATE PROJETO.Tarefa SET disabled = 1 WHERE id = @id;
		END
	ELSE
		-- N�o h� depend�ncias
		BEGIN
			BEGIN TRANSACTION
				DECLARE @code VARCHAR(20);
				SELECT @code = codigo_criador FROM DELETED;

				DELETE FROM PROJETO.Ficheiro WHERE codigo_criador = @code;
				DELETE FROM PROJETO.Criador WHERE codigo = @code;
				DELETE FROM PROJETO.Tarefa WHERE id = @id;
			COMMIT
		END
END

-- Ver se podemos eliminar ou se h� depend�ncias
CREATE TRIGGER deleteCadeira
ON PROJETO.Cadeira
INSTEAD OF DELETE
AS
BEGIN
	-- Basicamente se n�o existir no ProfessorCadeira pode eliminar, porque n�o h� nenhuma depend�ncia

	DECLARE @n INT, @id INT;
	SELECT @id = id FROM DELETED;

	SELECT @n = COUNT(*) FROM PROJETO.ProfessorCadeira WHERE cadeira = @id;

	IF @n > 0
		BEGIN
			UPDATE PROJETO.Cadeira SET disabled = 1 WHERE id = @id;
		END
	ELSE
		-- N�o h� depend�ncias
		BEGIN
			BEGIN TRANSACTION
				DECLARE @code VARCHAR(20);
				SELECT @code = codigo_criador FROM DELETED;

				DELETE FROM PROJETO.Ficheiro WHERE codigo_criador = @code;
				DELETE FROM PROJETO.Criador WHERE codigo = @code;
				DELETE FROM PROJETO.Cadeira WHERE id = @id;
			COMMIT
		END
END

-- Ver se podemos eliminar ou se h� depend�ncias
CREATE TRIGGER deleteProfessor
ON PROJETO.Professor
INSTEAD OF DELETE
AS
BEGIN
	-- Basicamente se n�o existir no ProfessorCadeira ou GrupoProfessor pode eliminar, porque n�o h� nenhuma depend�ncia

	DECLARE @n INT, @x INT, @email VARCHAR(250);
	SELECT @email = email FROM DELETED;

	SELECT @n = COUNT(*) FROM PROJETO.ProfessorCadeira WHERE professor = @email;
	SELECT @n = COUNT(*) FROM PROJETO.GrupoProfessor WHERE professor = @email;

	IF @n > 0 OR @x > 0
		BEGIN
			UPDATE PROJETO.Professor SET disabled = 1 WHERE email = @email;
		END
	ELSE
		-- N�o h� depend�ncias
		BEGIN
			BEGIN TRANSACTION
				DELETE FROM PROJETO.Professor WHERE email = @email;
			COMMIT
		END
END

-- Ver se podemos eliminar ou se h� depend�ncias
CREATE TRIGGER deleteGrupo
ON PROJETO.Grupo
INSTEAD OF DELETE
AS
BEGIN
	-- Basicamente se n�o existir no ProfessorCadeira ou GrupoProfessor pode eliminar, porque n�o h� nenhuma depend�ncia

	DECLARE @id INT;
	SELECT @id = id FROM DELETED;

	BEGIN TRANSACTION			
		DECLARE @code VARCHAR(20);
		SELECT @code = codigo_criador FROM DELETED;

		DELETE FROM PROJETO.TarefaGrupo WHERE grupo = @id;
		DELETE FROM PROJETO.PaginaGrupo WHERE grupo = @id;
		DELETE FROM PROJETO.GrupoProfessor WHERE grupo = @id;
		DELETE FROM PROJETO.Ficheiro WHERE codigo_criador = @code;
		DELETE FROM PROJETO.Criador WHERE codigo = @code;
		DELETE FROM PROJETO.Grupo WHERE id = @id;
	COMMIT

END

-- apagar uma institui��o pressup�e eliminar todas as tarefas associadas e tudo associado � cadeira
-- ou seja, a sp da institui��o chama a sp de delete de cadeiras

-- SP de Login
CREATE PROCEDURE PROJETO.login
		@email VARCHAR(250), @password VARCHAR(100)
AS
	BEGIN
		IF EXISTS (SELECT * FROM PROJETO.Aluno WHERE email = @email AND password = @password AND disabled = 0)
			SELECT 1
		ELSE
			SELECT 0

	END;
GO

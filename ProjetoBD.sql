USE p9g5;
GO

CREATE SCHEMA PROJETO;
GO

CREATE TABLE PROJETO.Criador (
	
	codigo VARCHAR(20) NOT NULL PRIMARY KEY

);

GO

CREATE TABLE PROJETO.Aluno (
	
	email VARCHAR(250) NOT NULL PRIMARY KEY,
	nome VARCHAR(250) NOT NULL,
	password VARCHAR(100) NOT NULL,
	data_nascimento DATE,
	disabled BIT DEFAULT 0

);

GO

CREATE TABLE PROJETO.Instituicao (
	
	id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	nome VARCHAR(250) NOT NULL,
	descricao VARCHAR(250) NOT NULL,
	aluno_criador VARCHAR(250) NOT NULL FOREIGN KEY REFERENCES PROJETO.Aluno(email),
	disabled BIT DEFAULT 0

);

GO

CREATE TABLE PROJETO.TipoTarefa (
	
	id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	designacao VARCHAR(250) NOT NULL,
	aluno_criador VARCHAR(250) NOT NULL FOREIGN KEY REFERENCES PROJETO.Aluno(email),
	disabled BIT DEFAULT 0

);

GO

CREATE TABLE PROJETO.Cadeira (
	
	id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	nome VARCHAR(250) NOT NULL,
	link VARCHAR(250),
	ano INT,
	semestre INT,
	nota_final FLOAT,
	aluno VARCHAR(250) NOT NULL FOREIGN KEY REFERENCES PROJETO.Aluno(email),
	codigo_criador VARCHAR(20) NOT NULL FOREIGN KEY REFERENCES PROJETO.Criador(codigo),
	instituicao INT NOT NULL FOREIGN KEY REFERENCES PROJETO.Instituicao(id),
	disabled BIT DEFAULT 0

);

GO

CREATE TABLE PROJETO.Grupo (
	
	id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	nome VARCHAR(250) NOT NULL,
	cadeira INT NOT NULL FOREIGN KEY REFERENCES PROJETO.Cadeira(id),
	codigo_criador VARCHAR(20) NOT NULL FOREIGN KEY REFERENCES PROJETO.Criador(codigo)

);

GO

CREATE TABLE PROJETO.Tarefa (
	
	id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	titulo VARCHAR(250) NOT NULL,
	descricao VARCHAR(250),
	completada_ts DATETIME,
	data_inicio DATE,
	date_final DATE,
	tipoTarefa INT NOT NULL FOREIGN KEY REFERENCES PROJETO.TipoTarefa(id),
	aluno VARCHAR(250) NOT NULL FOREIGN KEY REFERENCES PROJETO.Aluno(email),
	cadeira INT FOREIGN KEY REFERENCES PROJETO.Cadeira(id),
	codigo_criador VARCHAR(20) NOT NULL FOREIGN KEY REFERENCES PROJETO.Criador(codigo)

);

GO

CREATE TABLE PROJETO.Pagina (
	
	id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	titulo VARCHAR(250) NOT NULL,
	texto TEXT,
	aluno VARCHAR(250) FOREIGN KEY REFERENCES PROJETO.Aluno(email),
	cadeira INT FOREIGN KEY REFERENCES PROJETO.Cadeira(id),
	codigo_criador VARCHAR(20) NOT NULL FOREIGN KEY REFERENCES PROJETO.Criador(codigo)

);

GO

CREATE TABLE PROJETO.Ficheiro (
	
	id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	nome VARCHAR(50) NOT NULL,
	localizacao VARCHAR(250) NOT NULL,
	aluno VARCHAR(250) NOT NULL FOREIGN KEY REFERENCES PROJETO.Aluno(email),
	codigo_criador VARCHAR(20) NOT NULL FOREIGN KEY REFERENCES PROJETO.Criador(codigo),
	disabled BIT DEFAULT 0

);

GO

CREATE TABLE PROJETO.Professor (

	email VARCHAR(250) NOT NULL PRIMARY KEY,
	nome VARCHAR(250) NOT NULL,
	disabled BIT DEFAULT 0

);

GO

CREATE TABLE PROJETO.ProfessorCadeira (

	professor VARCHAR(250) NOT NULL FOREIGN KEY REFERENCES PROJETO.Professor(email),
	cadeira INT NOT NULL FOREIGN KEY REFERENCES PROJETO.Cadeira(id)

);

GO

CREATE TABLE PROJETO.GrupoProfessor (

	grupo INT NOT NULL FOREIGN KEY REFERENCES PROJETO.Grupo(id),
	professor VARCHAR(250) NOT NULL FOREIGN KEY REFERENCES PROJETO.Professor(email)

);

GO

CREATE TABLE PROJETO.GrupoAluno (

	grupo INT NOT NULL FOREIGN KEY REFERENCES PROJETO.Grupo(id),
	aluno VARCHAR(250) NOT NULL FOREIGN KEY REFERENCES PROJETO.Aluno(email),
	disabled BIT DEFAULT 0

);

GO

CREATE TABLE PROJETO.TarefaGrupo (

	tarefa INT NOT NULL FOREIGN KEY REFERENCES PROJETO.Tarefa(id),
	grupo INT NOT NULL FOREIGN KEY REFERENCES PROJETO.Grupo(id)

);

GO

CREATE TABLE PROJETO.PaginaGrupo (

	pagina INT NOT NULL FOREIGN KEY REFERENCES PROJETO.Pagina(id),
	grupo INT NOT NULL FOREIGN KEY REFERENCES PROJETO.Grupo(id)

);

GO

--DROP TABLE PROJETO.PaginaGrupo;
--DROP TABLE PROJETO.TarefaGrupo;
--DROP TABLE PROJETO.GrupoAluno;
--DROP TABLE PROJETO.GrupoProfessor;
--DROP TABLE PROJETO.ProfessorCadeira;
--DROP TABLE PROJETO.Professor;
--DROP TABLE PROJETO.Ficheiro;
--DROP TABLE PROJETO.Pagina;
--DROP TABLE PROJETO.Tarefa;
--DROP TABLE PROJETO.Grupo;
--DROP TABLE PROJETO.Cadeira;
--DROP TABLE PROJETO.TipoTarefa;
--DROP TABLE PROJETO.Instituicao;
--DROP TABLE PROJETO.Aluno;
--DROP TABLE PROJETO.Criador;
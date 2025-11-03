-- =========================================================
-- SCRIPT 1 - DDL (MySQL 8.0) - CRIAÇÃO DO ESQUEMA
-- =========================================================

-- ===== Database =====
CREATE DATABASE IF NOT EXISTS transito
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
USE transito;

-- (Opcional) Limpeza para reexecução do DDL
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS infracao;
DROP TABLE IF EXISTS agente_transito;
DROP TABLE IF EXISTS tipoinfracao;
DROP TABLE IF EXISTS local_infracao;
DROP TABLE IF EXISTS veiculo;
DROP TABLE IF EXISTS modelo;
DROP TABLE IF EXISTS categoria;
DROP TABLE IF EXISTS endereco;
DROP TABLE IF EXISTS telefone;
DROP TABLE IF EXISTS proprietario;
SET FOREIGN_KEY_CHECKS = 1;

-- ===== PROPRIETARIO =====
CREATE TABLE IF NOT EXISTS proprietario (
    cpf              VARCHAR(14)  NOT NULL,
    data_nascimento  DATE NULL,
    idade            INT NULL,
    sexo             ENUM('M','F','O') NULL,  -- O = outro/não informado
    CONSTRAINT pk_proprietario PRIMARY KEY (cpf),
    CONSTRAINT chk_idade_prop CHECK (idade IS NULL OR (idade BETWEEN 16 AND 120))
) ENGINE=InnoDB;

-- ===== TELEFONE (muitos por proprietário; FK opcional) =====
CREATE TABLE IF NOT EXISTS telefone (
    ddd              SMALLINT UNSIGNED NOT NULL,
    numero           VARCHAR(20) NOT NULL,
    proprietario_cpf VARCHAR(14) NULL,
    CONSTRAINT pk_telefone PRIMARY KEY (ddd, numero),
    CONSTRAINT fk_tel_prop
        FOREIGN KEY (proprietario_cpf)
        REFERENCES proprietario(cpf)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT chk_ddd CHECK (ddd BETWEEN 10 AND 99)
) ENGINE=InnoDB;

CREATE INDEX idx_telefone_prop ON telefone (proprietario_cpf);

-- ===== ENDERECO (1..N por proprietário; FK obrigatória) =====
CREATE TABLE IF NOT EXISTS endereco (
    id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    proprietario_cpf VARCHAR(14) NOT NULL,
    logradouro       VARCHAR(120) NULL,
    numero           VARCHAR(10) NULL,
    complemento      VARCHAR(60) NULL,
    bairro           VARCHAR(80) NULL,
    cidade           VARCHAR(80) NULL,
    estado           CHAR(2) NULL,
    cep              VARCHAR(9) NULL,
    CONSTRAINT pk_endereco PRIMARY KEY (id),
    CONSTRAINT fk_end_prop
        FOREIGN KEY (proprietario_cpf)
        REFERENCES proprietario(cpf)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_endereco_prop ON endereco (proprietario_cpf);

-- ===== CATEGORIA =====
CREATE TABLE IF NOT EXISTS categoria (
    num_serie_cat  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome           VARCHAR(60) NOT NULL,
    CONSTRAINT pk_categoria PRIMARY KEY (num_serie_cat),
    CONSTRAINT uq_categoria_nome UNIQUE (nome)
) ENGINE=InnoDB;

-- ===== MODELO =====
CREATE TABLE IF NOT EXISTS modelo (
    num_serie_mod  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome           VARCHAR(80) NOT NULL,
    CONSTRAINT pk_modelo PRIMARY KEY (num_serie_mod),
    CONSTRAINT uq_modelo_nome UNIQUE (nome)
) ENGINE=InnoDB;

-- ===== VEICULO (FKs: categoria, modelo, proprietario opcional) =====
CREATE TABLE IF NOT EXISTS veiculo (
    placa             VARCHAR(10)  NOT NULL,
    chassi            VARCHAR(30)  NOT NULL,
    cor               VARCHAR(30)  NULL,
    ano               INT NULL, -- validado por triggers
    categoria_id      BIGINT UNSIGNED NOT NULL,
    modelo_id         BIGINT UNSIGNED NOT NULL,
    proprietario_cpf  VARCHAR(14) NULL,
    CONSTRAINT pk_veiculo PRIMARY KEY (placa),
    CONSTRAINT uq_veiculo_chassi UNIQUE (chassi),
    CONSTRAINT fk_vei_cat
        FOREIGN KEY (categoria_id)
        REFERENCES categoria(num_serie_cat)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_vei_mod
        FOREIGN KEY (modelo_id)
        REFERENCES modelo(num_serie_mod)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_vei_prop
        FOREIGN KEY (proprietario_cpf)
        REFERENCES proprietario(cpf)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE INDEX idx_veiculo_categoria  ON veiculo (categoria_id);
CREATE INDEX idx_veiculo_modelo     ON veiculo (modelo_id);
CREATE INDEX idx_veiculo_prop       ON veiculo (proprietario_cpf);

-- ===== LOCAL_INFRACAO =====
CREATE TABLE IF NOT EXISTS local_infracao (
    id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    local_nome      VARCHAR(120) NULL,
    latitude        DECIMAL(9,6)  NOT NULL,
    longitude       DECIMAL(9,6)  NOT NULL,
    velocidade_max  SMALLINT UNSIGNED NULL,
    CONSTRAINT pk_local PRIMARY KEY (id),
    CONSTRAINT chk_lat CHECK (latitude BETWEEN -90 AND 90),
    CONSTRAINT chk_lon CHECK (longitude BETWEEN -180 AND 180),
    CONSTRAINT chk_vel_max CHECK (velocidade_max IS NULL OR (velocidade_max BETWEEN 0 AND 200))
) ENGINE=InnoDB;

CREATE INDEX idx_local_geo ON local_infracao (latitude, longitude);

-- ===== TIPOINFRACAO =====
CREATE TABLE IF NOT EXISTS tipoinfracao (
    codigo           VARCHAR(10) NOT NULL,
    valor_atribuido  DECIMAL(10,2) NOT NULL,
    CONSTRAINT pk_tipoinfracao PRIMARY KEY (codigo),
    CONSTRAINT chk_valor_atr CHECK (valor_atribuido >= 0)
) ENGINE=InnoDB;

-- ===== AGENTE_TRANSITO =====
CREATE TABLE IF NOT EXISTS agente_transito (
    matricula         VARCHAR(20) NOT NULL,
    nome              VARCHAR(120) NOT NULL,
    data_contratacao  DATE NULL,
    tempo_servico     SMALLINT UNSIGNED NULL,   -- anos de serviço
    CONSTRAINT pk_agente PRIMARY KEY (matricula)
) ENGINE=InnoDB;

-- ===== INFRACAO (FKs: veiculo, local, tipo, agente) =====
CREATE TABLE IF NOT EXISTS infracao (
    id                 BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    momento            DATETIME NOT NULL,
    velocidade_aferida DECIMAL(6,2) NULL,
    veiculo_placa      VARCHAR(10) NOT NULL,
    local_id           BIGINT UNSIGNED NOT NULL,
    tipo_codigo        VARCHAR(10) NOT NULL,
    agente_matricula   VARCHAR(20) NOT NULL,
    CONSTRAINT pk_infracao PRIMARY KEY (id),

    CONSTRAINT fk_inf_veiculo
        FOREIGN KEY (veiculo_placa)
        REFERENCES veiculo(placa)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_inf_local
        FOREIGN KEY (local_id)
        REFERENCES local_infracao(id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_inf_tipo
        FOREIGN KEY (tipo_codigo)
        REFERENCES tipoinfracao(codigo)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_inf_agente
        FOREIGN KEY (agente_matricula)
        REFERENCES agente_transito(matricula)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_vel_aferida CHECK (velocidade_aferida IS NULL OR velocidade_aferida >= 0),

    -- Evita duplicidade no mesmo instante para o mesmo veículo/local/tipo
    CONSTRAINT uq_infracao_unica_no_instante
        UNIQUE (momento, veiculo_placa, local_id, tipo_codigo)
) ENGINE=InnoDB;

CREATE INDEX idx_infracao_momento ON infracao (momento);
CREATE INDEX idx_infracao_veiculo ON infracao (veiculo_placa);
CREATE INDEX idx_infracao_local   ON infracao (local_id);
CREATE INDEX idx_infracao_tipo    ON infracao (tipo_codigo);
CREATE INDEX idx_infracao_agente  ON infracao (agente_matricula);

-- ===== TRIGGERS para validar 'ano' do veículo =====
DELIMITER //

CREATE TRIGGER veiculo_chk_ano_ins
BEFORE INSERT ON veiculo
FOR EACH ROW
BEGIN
  IF NEW.ano IS NOT NULL AND (NEW.ano < 1900 OR NEW.ano > YEAR(CURDATE()) + 1) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Ano de veículo inválido (deve estar entre 1900 e o ano atual + 1).';
  END IF;
END;
//

CREATE TRIGGER veiculo_chk_ano_upd
BEFORE UPDATE ON veiculo
FOR EACH ROW
BEGIN
  IF NEW.ano IS NOT NULL AND (NEW.ano < 1900 OR NEW.ano > YEAR(CURDATE()) + 1) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Ano de veículo inválido (deve estar entre 1900 e o ano atual + 1).';
  END IF;
END;
//

DELIMITER ;

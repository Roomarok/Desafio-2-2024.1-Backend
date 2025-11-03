-- =========================================================
-- SCRIPT 2 - DML (MySQL 8.0) - POPULAÇÃO DO ESQUEMA
-- =========================================================

USE transito;

-- Limpeza para reexecução do DML
SET FOREIGN_KEY_CHECKS = 0;
DELETE FROM infracao;
DELETE FROM veiculo;
DELETE FROM modelo;
DELETE FROM categoria;
DELETE FROM tipoinfracao;
DELETE FROM local_infracao;
DELETE FROM agente_transito;
DELETE FROM telefone;
DELETE FROM endereco;
DELETE FROM proprietario;
SET FOREIGN_KEY_CHECKS = 1;

-- ===== PROPRIETARIO (>=5) =====
INSERT INTO proprietario (cpf, data_nascimento, idade, sexo) VALUES
('111.111.111-11', '1985-03-15', 39, 'M'),
('222.222.222-22', '1990-07-22', 34, 'F'),
('333.333.333-33', '1978-12-05', 46, 'M'),
('444.444.444-44', '2001-01-30', 24, 'F'),
('555.555.555-55', '1996-09-12', 28, 'O'),
('666.666.666-66', '1988-11-08', 36, 'M');

-- ===== TELEFONE (>=5) =====
INSERT INTO telefone (ddd, numero, proprietario_cpf) VALUES
(61, '98888-1111', '111.111.111-11'),
(61, '97777-2222', '222.222.222-22'),
(61, '96666-3333', '333.333.333-33'),
(61, '95555-4444', '444.444.444-44'),
(61, '94444-5555', '555.555.555-55'),
(61, '93333-1111', '111.111.111-11'); -- proprietário 111 com 2 telefones

-- ===== ENDERECO (>=5) =====
INSERT INTO endereco (proprietario_cpf, logradouro, numero, complemento, bairro, cidade, estado, cep) VALUES
('111.111.111-11', 'SQN 112 Bloco A', '10', 'Ap 101', 'Asa Norte', 'Brasília', 'DF', '70762-000'),
('222.222.222-22', 'SHIS QI 05', '25', NULL, 'Lago Sul', 'Brasília', 'DF', '71600-000'),
('333.333.333-33', 'SQS 308 Bloco C', '20', 'Ap 402', 'Asa Sul', 'Brasília', 'DF', '70362-030'),
('444.444.444-44', 'CLN 204 Bloco B', '5', 'Sala 210', 'Asa Norte', 'Brasília', 'DF', '70843-520'),
('555.555.555-55', 'SIG Quadra 01', '100', NULL, 'SIG', 'Brasília', 'DF', '70610-410'),
('111.111.111-11', 'SHCGN 704', '3', 'Casa 02', 'Asa Norte', 'Brasília', 'DF', '70730-000');

-- ===== CATEGORIA (>=5) =====
INSERT INTO categoria (nome) VALUES
('Passeio'),
('Utilitário'),
('SUV'),
('Caminhão'),
('Moto'),
('Van');

-- ===== MODELO (>=5) =====
INSERT INTO modelo (nome) VALUES
('Sedan X'),
('Hatch Y'),
('SUV Z'),
('Truck T100'),
('Moto M1'),
('Van V7');

-- ===== VEICULO (>=5) =====
INSERT INTO veiculo (placa, chassi, cor, ano, categoria_id, modelo_id, proprietario_cpf) VALUES
('ABC1D23', '9BWZZZ377VT004251', 'Prata', YEAR(CURDATE()) - 1,
 (SELECT num_serie_cat FROM categoria WHERE nome='Passeio'),
 (SELECT num_serie_mod FROM modelo   WHERE nome='Sedan X'),
 '111.111.111-11'),

('XYZ9Z99', '9BWZZZ377VT004252', 'Preto', YEAR(CURDATE()) - 5,
 (SELECT num_serie_cat FROM categoria WHERE nome='Utilitário'),
 (SELECT num_serie_mod FROM modelo   WHERE nome='Hatch Y'),
 '222.222.222-22'),

('JKL5M67', '9BWZZZ377VT004253', 'Branco', YEAR(CURDATE()),
 (SELECT num_serie_cat FROM categoria WHERE nome='SUV'),
 (SELECT num_serie_mod FROM modelo   WHERE nome='SUV Z'),
 '333.333.333-33'),

('QWE8R90', '9BWZZZ377VT004254', 'Azul', YEAR(CURDATE()) - 8,
 (SELECT num_serie_cat FROM categoria WHERE nome='Caminhão'),
 (SELECT num_serie_mod FROM modelo   WHERE nome='Truck T100'),
 NULL), -- sem proprietário

('MNO2P34', '9BWZZZ377VT004255', 'Vermelho', YEAR(CURDATE()) - 2,
 (SELECT num_serie_cat FROM categoria WHERE nome='Moto'),
 (SELECT num_serie_mod FROM modelo   WHERE nome='Moto M1'),
 '444.444.444-44'),

('RST3U45', '9BWZZZ377VT004256', 'Cinza', YEAR(CURDATE()) - 3,
 (SELECT num_serie_cat FROM categoria WHERE nome='Van'),
 (SELECT num_serie_mod FROM modelo   WHERE nome='Van V7'),
 '555.555.555-55');

-- ===== LOCAL_INFRACAO (>=5) =====
INSERT INTO local_infracao (local_nome, latitude, longitude, velocidade_max) VALUES
('Eixo Monumental',     -15.793889, -47.882778, 80),
('Tesourinha 109/110',  -15.778500, -47.887300, 60),
('L2 Norte',            -15.746900, -47.885500, 70),
('EPIA BR-040',         -15.872200, -47.944400, 90),
('EPTG',                -15.817500, -47.973100, 80),
('L4 Sul',              -15.821300, -47.856900, 70);

-- ===== TIPOINFRACAO (>=5) =====
INSERT INTO tipoinfracao (codigo, valor_atribuido) VALUES
('A01', 130.16),
('A02', 195.23),
('B01', 293.47),
('B02', 880.41),
('C01', 293.47),
('D01', 1467.35);

-- ===== AGENTE_TRANSITO (>=5) =====
INSERT INTO agente_transito (matricula, nome, data_contratacao, tempo_servico) VALUES
('AGT100', 'Agente Souza',   '2018-02-10', 6),
('AGT101', 'Agente Lima',    '2019-06-01', 5),
('AGT102', 'Agente Santos',  '2021-03-15', 3),
('AGT103', 'Agente Ribeiro', '2017-11-20', 7),
('AGT104', 'Agente Costa',   '2020-08-05', 4),
('AGT105', 'Agente Alves',   '2015-04-12', 10);

-- ===== INFRACAO (>=5) =====
SET @now := NOW();

INSERT INTO infracao (momento, velocidade_aferida, veiculo_placa, local_id, tipo_codigo, agente_matricula) VALUES
(DATE_ADD(@now, INTERVAL -10 MINUTE), 95.2,
 'ABC1D23',
 (SELECT id FROM local_infracao WHERE local_nome='Eixo Monumental'),
 'B01',
 'AGT100'),

(DATE_ADD(@now, INTERVAL -9 MINUTE),  112.8,
 'JKL5M67',
 (SELECT id FROM local_infracao WHERE local_nome='EPIA BR-040'),
 'B02',
 'AGT101'),

(DATE_ADD(@now, INTERVAL -8 MINUTE),  68.0,
 'XYZ9Z99',
 (SELECT id FROM local_infracao WHERE local_nome='L2 Norte'),
 'A02',
 'AGT102'),

(DATE_ADD(@now, INTERVAL -7 MINUTE),  82.4,
 'RST3U45',
 (SELECT id FROM local_infracao WHERE local_nome='EPTG'),
 'A01',
 'AGT103'),

(DATE_ADD(@now, INTERVAL -6 MINUTE),  64.3,
 'MNO2P34',
 (SELECT id FROM local_infracao WHERE local_nome='Tesourinha 109/110'),
 'C01',
 'AGT104'),

(DATE_ADD(@now, INTERVAL -5 MINUTE),  88.9,
 'QWE8R90',
 (SELECT id FROM local_infracao WHERE local_nome='L4 Sul'),
 'D01',
 'AGT105');

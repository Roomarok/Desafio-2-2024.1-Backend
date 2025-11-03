/* =========================================================
   SCRIPT CONSULTA - MySQL 8.0
   Autor: Erick + Copilot
   Objetivo: SELECTs frequentes sobre o modelo "transito"
   ========================================================= */

USE transito;

/* ---------------------------------------------------------
   A) Todos os dados dos veículos de um determinado proprietário (CPF)
   Parâmetro: :cpf (substituir pelo CPF desejado)x
   Retorna: dados do veículo + modelo + categoria + CPF do proprietário
   --------------------------------------------------------- */
-- Consulta (A)
SELECT
    v.placa,
    v.chassi,
    v.cor,
    v.ano,
    m.num_serie_mod  AS modelo_id,
    m.nome           AS modelo,
    c.num_serie_cat  AS categoria_id,
    c.nome           AS categoria,
    v.proprietario_cpf AS cpf_proprietario
FROM veiculo v
JOIN modelo   m ON m.num_serie_mod = v.modelo_id
JOIN categoria c ON c.num_serie_cat = v.categoria_id
WHERE v.proprietario_cpf = :cpf;

-- Exemplo de uso (remova os dois-pontos e troque o CPF):
-- SELECT ... WHERE v.proprietario_cpf = '111.111.111-11';


/* ---------------------------------------------------------
   B) Consultar proprietário(s) por qualquer parte do nome
   Parâmetro: :termo (texto parcial, sem % — colocamos as % na query)
   Observação: LIKE é case/accent-insensitive nesta collation
   --------------------------------------------------------- */
-- Consulta (B)
SELECT
    p.cpf,
    p.data_nascimento,
    p.idade,
    p.sexo
FROM proprietario p
WHERE p.nome LIKE CONCAT('%', :termo, '%')
ORDER BY p.nome;

-- Exemplo de uso:
-- SELECT ... WHERE p.nome LIKE CONCAT('%', 'sou', '%');


/* ---------------------------------------------------------
   C) Dados da infração e do veículo em um período (DE ... ATÉ ...)
   Parâmetros: :de (DATETIME), :ate (DATETIME)
   Retorna: dados de infração + veículo + modelo + categoria + local + tipo + agente
   --------------------------------------------------------- */
-- Consulta (C)
SELECT
    i.id               AS infracao_id,
    i.momento,
    i.velocidade_aferida,
    v.placa,
    v.chassi,
    v.cor,
    v.ano,
    m.nome             AS modelo,
    c.nome             AS categoria,
    l.local_nome,
    l.latitude,
    l.longitude,
    l.velocidade_max,
    t.codigo           AS tipo_codigo,
    t.valor_atribuido,
    a.matricula        AS agente_matricula,
    a.nome             AS agente_nome
FROM infracao i
JOIN veiculo v           ON v.placa = i.veiculo_placa
JOIN modelo  m           ON m.num_serie_mod = v.modelo_id
JOIN categoria c         ON c.num_serie_cat = v.categoria_id
JOIN local_infracao l    ON l.id = i.local_id
JOIN tipoinfracao t      ON t.codigo = i.tipo_codigo
JOIN agente_transito a   ON a.matricula = i.agente_matricula
WHERE i.momento BETWEEN :de AND :ate
ORDER BY i.momento DESC;

-- Exemplos de uso:
-- WHERE i.momento BETWEEN '2025-11-01 00:00:00' AND '2025-11-02 23:59:59';
-- WHERE i.momento BETWEEN '2025-11-02 00:00:00' AND '2025-11-02 23:59:59';


/* ---------------------------------------------------------
   D) Número de veículos cadastrados em cada modelo
   Ordenado pelo número de veículos em ordem decrescente
   --------------------------------------------------------- */
-- Consulta (D)
SELECT
    m.num_serie_mod  AS modelo_id,
    m.nome           AS modelo,
    COUNT(v.placa)   AS total_veiculos
FROM modelo m
LEFT JOIN veiculo v
  ON v.modelo_id = m.num_serie_mod
GROUP BY m.num_serie_mod, m.nome
ORDER BY total_veiculos DESC, m.nome;

-- Observação: LEFT JOIN garante que modelos sem veículos apareçam com total = 0.

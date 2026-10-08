-- ============================================================
-- DDL : Table BALANCE_ANALYTIQUE
-- Schema : bi_{entite_name}
-- Mode   : Full Reload (TRUNCATE + INSERT)
-- ============================================================

CREATE TABLE balance_analytique (
    -- Colonnes Fonctionnelles
    NUM_PIECE       VARCHAR2(30)    NOT NULL,
    COMPTE          VARCHAR2(28)    NOT NULL,
    SENS            NUMBER(1)       NOT NULL,
    AXE_CENTRE      VARCHAR2(20),
    AXE_ENTITE      VARCHAR2(10),
    AXE_BLINE       VARCHAR2(30),
    AXE_SITE        VARCHAR2(10),
    MONTANT         NUMBER(15,2)    NOT NULL,
    TIERS_CODE      VARCHAR2(20),
    ARTICLE_CODE    VARCHAR2(20),
    DATE_COMPTABLE  DATE            NOT NULL,

    -- Colonnes Techniques
    SOURCE          VARCHAR2(20)    NOT NULL,
    TYPE_LIGNE      VARCHAR2(25)    NOT NULL,
    DATE_INSERTION  TIMESTAMP       DEFAULT SYSTIMESTAMP
);

-- Index sur les clés de recherche fréquentes
CREATE INDEX idx_bal_num_piece    ON balance_analytique (NUM_PIECE);
CREATE INDEX idx_bal_compte       ON balance_analytique (COMPTE);
CREATE INDEX idx_bal_date         ON balance_analytique (DATE_COMPTABLE);
CREATE INDEX idx_bal_source       ON balance_analytique (SOURCE);
CREATE INDEX idx_bal_type_ligne   ON balance_analytique (TYPE_LIGNE);

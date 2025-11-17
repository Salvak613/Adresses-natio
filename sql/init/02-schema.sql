DROP TABLE IF EXISTS alias CASCADE;
DROP TABLE IF EXISTS adresse CASCADE;
DROP TABLE IF EXISTS position CASCADE;
DROP TABLE IF EXISTS voie CASCADE;
DROP TABLE IF EXISTS desserte_postale CASCADE;
DROP TABLE IF EXISTS code_postal CASCADE;
DROP TABLE IF EXISTS commune_ancienne CASCADE;
DROP TABLE IF EXISTS commune CASCADE;
DROP TABLE IF EXISTS departement CASCADE;

CREATE TABLE departement (
    id SERIAL PRIMARY KEY,
    code_departement VARCHAR(3) UNIQUE NOT NULL,
    nom_departement VARCHAR(100) NOT NULL,

    CONSTRAINT chk_departement_code_format 
        CHECK (code_departement ~ '^([0-9]{2}|[0-9]{3}|2[AB])$')
);

CREATE TABLE commune (
    id SERIAL PRIMARY KEY,
    code_insee VARCHAR(5) UNIQUE NOT NULL,
    nom_commune VARCHAR(100) NOT NULL,
    nom_afnor VARCHAR(100),
    id_departement INTEGER NOT NULL,

    CONSTRAINT fk_commune_departement 
        FOREIGN KEY (id_departement) 
        REFERENCES departement(id)
        ON UPDATE CASCADE,

    CONSTRAINT chk_commune_code_insee_format
        CHECK (code_insee ~ '^([0-9]{5}|2[AB][0-9]{3})$')
);

CREATE TABLE code_postal (
    id SERIAL PRIMARY KEY,
    code_postal VARCHAR(5) UNIQUE NOT NULL,
    libelle_acheminement VARCHAR(100),
    

    CONSTRAINT chk_code_postal_format 
        CHECK (code_postal ~ '^[0-9]{5}$')
);

CREATE TABLE desserte_postale (
    id SERIAL PRIMARY KEY,
    id_commune INTEGER NOT NULL,
    id_code_postal INTEGER NOT NULL,
    
    CONSTRAINT fk_desserte_commune 
        FOREIGN KEY (id_commune) 
        REFERENCES commune(id)
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
        
    CONSTRAINT fk_desserte_code_postal 
        FOREIGN KEY (id_code_postal) 
        REFERENCES code_postal(id)
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    CONSTRAINT uk_desserte_postale 
        UNIQUE (id_commune, id_code_postal)
);

CREATE TABLE commune_ancienne (
    id SERIAL PRIMARY KEY,
    code_insee_ancienne VARCHAR(5) UNIQUE NOT NULL,
    nom_ancienne_commune VARCHAR(100) NOT NULL,
    date_fusion DATE,
    id_commune_nouvelle INTEGER NOT NULL,
    
    CONSTRAINT fk_commune_ancienne_nouvelle 
        FOREIGN KEY (id_commune_nouvelle) 
        REFERENCES commune(id)
        ON UPDATE CASCADE,
    
    CONSTRAINT chk_commune_ancienne_code_format 
        CHECK (code_insee_ancienne ~ '^[0-9]{2}[0-9AB][0-9]{2}$'),
        
    CONSTRAINT chk_commune_ancienne_date_fusion 
        CHECK (date_fusion IS NULL OR date_fusion <= CURRENT_DATE)
);

CREATE TABLE voie (
    id SERIAL PRIMARY KEY,
    id_fantoir VARCHAR(20) UNIQUE NOT NULL,
    nom_voie VARCHAR(200) NOT NULL,
    nom_afnor VARCHAR(200),
    type_voie VARCHAR(50),
    id_commune INTEGER NOT NULL,
    
    CONSTRAINT fk_voie_commune 
        FOREIGN KEY (id_commune) 
        REFERENCES commune(id)
        ON UPDATE CASCADE
);

CREATE TABLE alias (
    id SERIAL PRIMARY KEY,
    nom_alias VARCHAR(200) NOT NULL,
    id_voie INTEGER NOT NULL,
    
    CONSTRAINT fk_alias_voie 
        FOREIGN KEY (id_voie) 
        REFERENCES voie(id)
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    CONSTRAINT uk_alias_voie 
        UNIQUE (nom_alias, id_voie)
);

CREATE TABLE position (
    id SERIAL PRIMARY KEY,
    x DECIMAL(12,2) NOT NULL,
    y DECIMAL(12,2) NOT NULL,
    lon DECIMAL(10,7) NOT NULL,
    lat DECIMAL(10,7) NOT NULL,
    type_position VARCHAR(50),
    
    CONSTRAINT uk_position_coords
        UNIQUE (x, y, lon, lat),
    
    CONSTRAINT chk_position_lat 
        CHECK (lat BETWEEN -90 AND 90),
        
    CONSTRAINT chk_position_lon 
        CHECK (lon BETWEEN -180 AND 180),
        
    CONSTRAINT chk_position_type 
        CHECK (type_position IS NULL OR type_position IN (
            'délivrance postale',
            'entrée',
            'bâtiment',
            'cage d''escalier',
            'logement',
            'parcelle',
            'segment',
            'service technique'
        ))
);

CREATE TABLE adresse (
    id SERIAL PRIMARY KEY,
    id_ban VARCHAR(50) UNIQUE NOT NULL,
    numero VARCHAR(10),
    rep VARCHAR(20),
    nom_ld VARCHAR(100),
    cad_parcelles TEXT,
    certification_commune BOOLEAN NOT NULL DEFAULT FALSE,
    date_creation TIMESTAMP NOT NULL DEFAULT NOW(),
    date_maj TIMESTAMP NOT NULL DEFAULT NOW(),
    source_position VARCHAR(50),
    source_nom_voie VARCHAR(50),
    id_voie INTEGER,
    id_position INTEGER NOT NULL,
    
    CONSTRAINT fk_adresse_voie 
        FOREIGN KEY (id_voie) 
        REFERENCES voie(id)
        ON DELETE SET NULL 
        ON UPDATE CASCADE,
        
    CONSTRAINT fk_adresse_position 
        FOREIGN KEY (id_position) 
        REFERENCES position(id)
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    
    CONSTRAINT chk_adresse_coherence 
        CHECK (
            (numero IS NOT NULL AND id_voie IS NOT NULL) 
            OR 
            nom_ld IS NOT NULL
        ),
        
    CONSTRAINT chk_adresse_dates 
        CHECK (date_maj >= date_creation),
        
    CONSTRAINT chk_adresse_source_position
        CHECK (source_position IS NULL OR source_position IN (
            'commune', 'cadastre', 'ign', 'arcep', 'laposte', 'inconnue'
        )),
        
    CONSTRAINT chk_adresse_source_nom_voie 
        CHECK (source_nom_voie IS NULL OR source_nom_voie IN (
            'commune', 'ign', 'cadastre', 'arcep', 'inconnue'
        ))
);


-- Index pour les clés étrangères (améliore les jointures et DELETE/UPDATE CASCADE)
CREATE INDEX idx_commune_departement ON commune(id_departement);
CREATE INDEX idx_desserte_commune ON desserte_postale(id_commune);
CREATE INDEX idx_desserte_code_postal ON desserte_postale(id_code_postal);
CREATE INDEX idx_commune_ancienne_nouvelle ON commune_ancienne(id_commune_nouvelle);
CREATE INDEX idx_voie_commune ON voie(id_commune);
CREATE INDEX idx_alias_voie ON alias(id_voie);
CREATE INDEX idx_adresse_voie ON adresse(id_voie);
CREATE INDEX idx_adresse_position ON adresse(id_position);

-- Index pour les recherches fréquentes
CREATE INDEX idx_commune_nom ON commune(nom_commune);
CREATE INDEX idx_voie_nom ON voie(nom_voie);
CREATE INDEX idx_position_coords ON position(lon, lat);
CREATE INDEX idx_adresse_date_maj ON adresse(date_maj);


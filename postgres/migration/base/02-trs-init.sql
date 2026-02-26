\connect configuration;

CREATE TABLE public.trs_rule_flow (
	id serial4 NOT NULL,
	rule_id int4 NOT NULL,
	flow_json_rule_builder jsonb NOT NULL,
	ts_file_base64_rule_builder text NULL,
	flow_json_test_case jsonb NOT NULL,
	ts_file_base64_test_case text NULL,
	tenant_id varchar(255) DEFAULT 'DEFAULT'::character varying NOT NULL,
	status_rule_builder varchar(255) DEFAULT 'initial'::character varying NULL,
	status_test_case varchar(255) DEFAULT 'initial'::character varying NULL,
	created_at date NULL,
	updated_at date NULL,
	CONSTRAINT trs_rule_flow_pkey PRIMARY KEY (id)
);
CREATE INDEX idx_trs_rule_flow_rule_id ON trs_rule_flow (rule_id);

CREATE TABLE trs_rules (
    rule_id SERIAL,
    rule_name VARCHAR(100),
    description VARCHAR(255) NOT NULL,
    tenant_id VARCHAR(255) NOT NULL,
    txtp VARCHAR(50) NOT NULL,
    version VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    publishing_status VARCHAR(255) NOT NULL,
    updated_by VARCHAR(255) NOT NULL,
    updated_at DATE,
    created_at DATE,
    flow_id INTEGER,
    PRIMARY KEY (rule_id, tenant_id, version),
    CONSTRAINT fk_trs_rules_flow_id FOREIGN KEY (flow_id) REFERENCES trs_rule_flow(id)
);

-- Index on tenant_id for faster retrieval of rules by tenant
CREATE INDEX idx_trs_rules_tenant_id ON trs_rules (tenant_id);

-- Index on status for faster filtering based on rule status
CREATE INDEX idx_trs_rules_status ON trs_rules (status);

-- Index on version for faster version-based queries
CREATE INDEX idx_trs_rules_version ON trs_rules (version);

-- Composite index if you frequently query by tenant_id and status together
CREATE INDEX idx_trs_rules_tenant_status ON trs_rules (tenant_id, status);

CREATE TABLE public.trs_nodes (
	id serial4 NOT NULL,
	node_json jsonb NOT NULL,
	tenant_id varchar(255) DEFAULT 'DEFAULT'::character varying NOT NULL,
	created_by varchar(255) NULL,
	"order" varchar(255) NULL,
	created_at date NULL,
	updated_at date NULL,
	CONSTRAINT trs_nodes_pkey PRIMARY KEY (id)
);

CREATE INDEX idx_nodes_tenant_id ON trs_nodes (tenant_id);

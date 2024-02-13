{% macro create_masking_policy_encrypt_pii(node_database, node_schema) %}

CREATE MASKING POLICY IF NOT EXISTS {{ node_database }}.{{ node_schema }}.encrypt_pii AS (val string) 
  RETURNS string ->
      CASE
        WHEN CURRENT_ROLE() IN ('TRANSFORMER') THEN val
        ELSE SHA2(val)
      END

{% endmacro %}
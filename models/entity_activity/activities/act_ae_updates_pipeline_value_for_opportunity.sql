{{
    config (
        materialized = 'table'
    )
}}
with cte_opportunity_history as (
    select
        entity_id,
        estimated_value as current_value,
        lag(estimated_value, 1) over(partition by entity_id order by observed_on asc) as previous_value,
        {{ dbt_utils.star(from=ref('ent_opportunities_history'), except=['estimated_value', 'entity_id'], quote_identifiers=False) }}
    from
        {{ ref('ent_opportunities_history') }}
    qualify
        current_value != previous_value
)
select
    o.entity_id || o.created_on as primary_key,
    'ae_updates_pipeline_value_for_business_opportunity' as activity_name,
    '{
        "entity":"Account_Executive",
        "entity_id":"'|| ae.entity_id ||'"",
        "entity_history_id":"'|| ae.entity_history_id ||'"
     }' as actor,
    '{
        "entity":"New_Business_Opportunity",
        "entity_id":"'|| o.entity_id ||'"",
        "entity_history_id":"'|| o.entity_history_id ||'"
     }' as object,
    o.created_on as activity_ts,
    o.observed_on,
    o.primary_contact_id,
    o.company_id,
    o.current_value as activity_value
from
    cte_opportunity_history o
    left join {{ ref('ent_employees_history') }} ae
        on o.owner_id = ae.entity_id
        and ae.observed_on = o.observed_on
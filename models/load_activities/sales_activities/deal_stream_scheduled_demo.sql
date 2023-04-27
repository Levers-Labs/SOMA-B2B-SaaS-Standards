{{-
    config(materialized = 'table')
-}}

{{-
generate_fake_data (
    activity_name = 'completed_demo',
    has_revenue_impact = false,
    feature_json_dict = '{"tenure": ["t1", "t2", "t3", "t4"]}'
  )
-}}

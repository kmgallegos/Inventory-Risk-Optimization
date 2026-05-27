# Inventory Risk Optimization Dashboard

End-to-end Business Intelligence project — SQL Server ETL pipeline combined with a Power BI executive dashboard covering inventory performance, stock risk, and commercial strategy for a fictional retail chain.

You can access the dashboard **[  here](https://app.powerbi.com/view?r=eyJrIjoiOWEyYzRlM2EtNGFiZS00ZjlkLTgxMjYtM2I5MTYzYjRkMWNhIiwidCI6IjBlMGNiMDYwLTA5YWQtNDlmNS1hMDA1LTY4YjliNDlhYTFmNiIsImMiOjR9&language=en-US)**

---

## Project Background

This project simulates a real-world retail analytics scenario where inventory data is transformed into actionable business insights. The dataset covers **760 days of operations** (January 2022 – January 2024) across **5 stores** and **64 products** in 4 categories.

The dataset was sourced from [Kaggle — Retail Store Inventory and Demand Forecasting](https://www.kaggle.com/datasets/atomicd/retail-store-inventory-and-demand-forecasting) and starts as a raw CSV file that goes through a full ETL pipeline in SQL Server before being consumed by Power BI. The goal was to build a dashboard that answers three business questions:

- Where does the business stand today? *(Executive Overview)*
- What inventory is at risk and how much capital is tied up? *(Inventory Risk)*
- Are pricing and discount strategies actually working? *(Commercial Strategy)*

---

## Data Structure

The SQL Server database `inventory` is organized into two schemas:

- `staging` — raw ingestion layer and clean view with type casting and calculated fields
- `dw` — star schema consumed by Power BI (Import mode)

The star schema consists of one fact table and four dimension tables:

| Table | Description | Rows |
|---|---|---|
| `dw.fact_inventory_sales` | Grain: Date × Store × Product. Contains metrics, calculated flags, and FKs | 76,000 |
| `dw.dim_date` | Date attributes: year, month, quarter, weekday, fiscal period | 760 |
| `dw.dim_store` | Store ID, region, and display name | 5 |
| `dw.dim_product` | Product ID, category, and display name | 64 |
| `dw.dim_weather` | Weather condition label | 4 |

Calculated columns (revenue, stock coverage days, restock/overstock flags, price gap vs. competitor) are computed in `staging.v_sales_clean` and stored directly in the fact table, keeping the DAX layer focused on aggregation only.

In Power BI, all measures are organized in a dedicated `_Measures` table.

<img width="1275" height="787" alt="Image" src="https://github.com/user-attachments/assets/630aec1d-42f3-4967-b63e-e35046b85153" />

---

## ETL Pipeline

The pipeline runs through 8 sequential T-SQL scripts:

| Script | Purpose |
|---|---|
| `00_create_database.sql` | Creates the `inventory` database |
| `01_create_staging.sql` | Creates schema and raw table |
| `02_load_data.sql` | `BULK INSERT` from CSV — update the file path before running |
| `03_create_clean_view.sql` | Typed columns + 10 calculated fields |
| `04_create_dimensions.sql` | Builds the 4 dimension tables |
| `05_create_fact_inventory_sales.sql` | Loads the fact table resolving FKs via JOIN |
| `06_validation_queries.sql` | Row counts, orphan key checks, duplicate detection |
| `07_add_display_names.sql` | Adds fictional product and store names for readability |

The pipeline was validated end-to-end: **0 orphan keys, 0 duplicates**.

---

## Executive Summary

**Page 1 — Executive Overview**

Provides a high-level snapshot of the business. Key metrics include Total Revenue, Fill Rate %, and Average Coverage Days. An alert card system highlights active Restock and Overstock situations using color-coded borders (red for restock risk, orange for overstock). The Monthly Revenue Trend line chart spans the full 2-year period with Min/Max analytics lines to surface seasonal peaks and troughs. Filters by date range and region allow drill-down without leaving the page.

<img width="1486" height="837" alt="Image" src="https://github.com/user-attachments/assets/f7b241ba-c7de-493c-b08e-2060c9e91d34" />

**Page 2 — Inventory Risk**

Focuses on quantifying the financial impact of stock imbalances. The headline figure is **$989M in capital tied up in overstock — equivalent to nearly 5 years of annual revenue**, with Groceries concentrating 38% of that risk. The page includes side-by-side Restock/Overstock breakdowns by category, a Top Products at Risk table with conditional formatting, and coverage day indicators to prioritize action.

<img width="1480" height="836" alt="Image" src="https://github.com/user-attachments/assets/323ee21a-b657-4448-b955-2c70e48ef705" />

**Page 3 — Commercial Strategy**

Evaluates pricing and discount effectiveness across the product portfolio. A scatter plot (Discount Efficiency) maps Fill Rate % against Average Discount % — sized by Units Sold and colored by Category — to identify which categories convert discount spend into actual sales and which do not. A clustered bar chart compares our prices against competitor pricing by category.

<img width="1483" height="835" alt="Image" src="https://github.com/user-attachments/assets/341c0633-03e4-42b3-a825-8476222e4ef0" />

---

## DAX Measures

Measures are grouped into five categories inside the `_Measures` table:

```
Base          → Total Revenue, Total Units Sold, Total Demand, Total Inventory, Total Available Stock
Efficiency    → Fill Rate %, Avg Discount %, Avg Price, Avg Competitor Price, Avg Price Gap vs Competitor
Alerts        → # Restock Alerts, % Restock Risk, # Overstock Alerts, % Overstock
Coverage      → Avg Coverage Days, Stock Shortage, Total Stock Demand Gap
Storytelling  → Capital at Risk ($989M), Years of Revenue at Risk (~5)
```
<img width="361" height="655" alt="Image" src="https://github.com/user-attachments/assets/3ce3d8a6-3b79-46d3-b7b0-f2918ffc3c94" />

---

## Conclusion

This project demonstrates a complete BI workflow: from raw data ingestion and SQL Server modeling to a multi-page Power BI dashboard with a consistent visual language and a clear narrative across pages. The pipeline is reproducible, validated, and documented so that any analyst can replicate it against their own SQL Server instance.

---

## Technologies Used

| Tool | Role |
|---|---|
| SQL Server (Developer Edition) | Database, ETL, star schema |
| T-SQL | 8 sequential ETL scripts |
| Power BI Desktop | Data modeling, DAX, dashboard |
| Power BI Service | Publishing and sharing |
| Custom JSON theme | Consistent dark visual design |

---

## How to Set Up

1. **Clone the repository**
   ```bash
   git clone https://github.com/kmgallegos/Inventory-Risk-Optimization.git
   ```

2. **Run the ETL scripts in order** using SSMS or Azure Data Studio (connect to your local SQL Server):
   ```
   sql/00 → 01 → 02 → 03 → 04 → 05 → 06 → 07
   ```
   > In `02_load_data.sql`, update the `BULK INSERT` path to match the location of `data/raw/sales_data.csv` on your machine.

3. **Connect Power BI Desktop** to your local SQL Server (`inventory` database, `dw` schema) using Import mode.

4. **Apply the theme** via *View → Themes → Browse for themes* and select `inventory_dark_theme.json`.

5. **Build your visuals** — recreate the three dashboard pages connecting to the `dw` schema tables. All measures and calculated columns are already available in the fact and dimension tables.

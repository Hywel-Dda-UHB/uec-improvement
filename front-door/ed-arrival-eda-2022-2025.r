
library(viridis)

df <- readRDS("./front-door/ed_data_all.rds")

df <- df %>% filter(HospitalLocation == 'Glangwili General Hospital')

df <- df %>% filter(ArrivalDate >= '2022-07-01')
df <- df %>% filter(ArrivalDate <= '2025-06-30')

df <- df %>%
  mutate(
    date_str = format(as.Date(ArrivalDate), "%Y-%m-%d"),
    arrival_datetime = as.POSIXct(paste(date_str, ArrivalTime), 
                                  format = "%Y-%m-%d %H:%M"),
    arrival_datetime = ifelse(is.na(arrival_datetime),
                              as.POSIXct(paste(date_str, ArrivalTime), 
                                         format = "%Y-%m-%d %H:%M:%S"),
                              arrival_datetime),
    arrival_datetime = as.POSIXct(arrival_datetime, origin = "1970-01-01"),
    day_of_week = weekdays(arrival_datetime),
    hour = hour(arrival_datetime),
    date = as.Date(arrival_datetime)
  ) %>%
  filter(!is.na(arrival_datetime))

hourly_data <- df %>%
  group_by(date, day_of_week, hour) %>%
  summarise(attendance_count = n(), .groups = 'drop')

percentiles <- hourly_data %>%
  group_by(day_of_week, hour) %>%
  summarise(
    p50 = quantile(attendance_count, 0.5),
    p75 = quantile(attendance_count, 0.75),
    p95 = quantile(attendance_count, 0.95),
    n_obs = n(),
    .groups = 'drop'
  ) %>%
  mutate(
    day_of_week = factor(day_of_week, 
                         levels = c("Monday", "Tuesday", "Wednesday", 
                                    "Thursday", "Friday", "Saturday", "Sunday")),
    day_num = as.numeric(day_of_week),
    x_pos = (day_num - 1) * 24 + hour
  )


ggplot(percentiles, aes(x = x_pos)) +
  geom_ribbon(aes(ymin = p50, ymax = p95), alpha = 0.2, fill = "grey90") +
  geom_line(aes(y = p95), color = "#333333", size = 0.5) + 
  geom_line(aes(y = p75), color = "#666666", size = 0.5) + 
  geom_line(aes(y = p50), color = "#999999", size = 0.5) +
  geom_vline(xintercept = seq(24, 144, 24), linetype = "dashed", 
             color = "darkgrey", alpha = 0.8) +
  scale_x_continuous(
    breaks = seq(12, 156, 24),
    labels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")
  ) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
  labs(
    title = "ED Arrival Distribution by Weekday and Hour",
    subtitle = "Glangwili General Hospital | 01-07-22 to 30-06-25 | Median, 75th, and 95th Percentile",
    x = "",
    y = "Hourly Arrivals"
  ) +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
        plot.subtitle = element_text(size = 12, hjust = 0.5, color = "grey30"),
        axis.text = element_text(face = "bold", size = 12),
        axis.title = element_text(size = 10, vjust = 0.5),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 10)) +
  theme(legend.position = "none")


percentiles$day_of_week <- factor(percentiles$day_of_week, 
                         levels = rev(c("Monday", "Tuesday", "Wednesday",
                                        "Thursday", "Friday",
                                        "Saturday", "Sunday")))

heatmap_data <- percentiles %>%
  select(day_of_week, hour, p50) %>%
  arrange(day_of_week, hour)


ggplot(heatmap_data, aes(x = hour, y = day_of_week, fill = p50)) +
  geom_tile() +
  scale_fill_gradient2(
    name = "Median\n Attendances\n",
    low = "lightgrey",
    mid = "salmon",
    high = "darkred",
    midpoint = median(heatmap_data$p50, na.rm = TRUE)
  ) +
  scale_x_continuous(breaks = seq(0, 23, 1)) +
  geom_tile(color = "white", size = 0.3) +
  labs(
    title = "ED Hourly Arrival Heatmap | Median Values",
    subtitle = "Glangwili General Hospital | 01-07-22 to 30-06-25",
    x = "Hour of Day (00:00 to 01:00, 01:00 to 02:00 etc)",
    y = ""
  ) +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
        plot.subtitle = element_text(size = 12, hjust = 0.5, color = "grey30"),
        axis.text = element_text(face = "bold", size = 12),
        axis.title = element_text(size = 10, vjust = 0.5),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 10)) +
  theme(legend.position = "none") +
  geom_text(aes(label = ifelse(p50 >= 0, round(p50, 0), "")),
            color = "snow", size = 3)

heatmap_data_p95 <- percentiles %>%
  select(day_of_week, hour, p95) %>%
  arrange(day_of_week, hour)

ggplot(heatmap_data_p95, aes(x = hour, y = day_of_week, fill = p95)) +
  geom_tile() +
  scale_fill_gradient2(
    name = "95th Percentile\n Arrivals\n",
    low = "lightgrey",
    mid = "salmon",
    high = "darkred",
    midpoint = median(heatmap_data_p95$p95, na.rm = TRUE)
  ) +
  scale_x_continuous(breaks = seq(0, 23, 1)) +
  geom_tile(color = "white", size = 0.3) +
  labs(
    title = "ED Hourly Arrival Heatmap | 95th Percentile Values",
    subtitle = "Glangwili General Hospital | 01-07-22 to 30-06-25",
    x = "Hour of Day (00:00 to 01:00, 01:00 to 02:00 etc)",
    y = ""
  ) +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
        plot.subtitle = element_text(size = 12, hjust = 0.5, color = "grey30"),
        axis.text = element_text(face = "bold", size = 12),
        axis.title = element_text(size = 10, vjust = 0.5),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 10)) +
  theme(legend.position = "none") +
  geom_text(aes(label = ifelse(p95 >= 0, round(p95, 0), "")),
            color = "snow", size = 3)



CREATE TABLE [ref].[filter_ihs_services]
(
    [bin_ihs_service_cd] INT NOT NULL 
        CONSTRAINT [pk_filter_ihs_services] PRIMARY KEY, 
    [bin_ihs_service_tx] VARCHAR(50) NOT NULL, 
    [min_display_date] DATE NULL
)

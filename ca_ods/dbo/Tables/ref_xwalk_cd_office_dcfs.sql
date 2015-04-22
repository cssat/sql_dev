CREATE TABLE [dbo].[ref_xwalk_cd_office_dcfs] (
    [cd_office]               INT           NOT NULL,
    [tx_office]               VARCHAR (255) NULL,
    [cd_office_collapse]      INT           NOT NULL,
    [tx_office_collapse]      VARCHAR (200) NULL,
    [cd_office_coll_cnty_srv] INT           NOT NULL,
    [tx_office_coll_cnty_srv] VARCHAR (255) NULL,
    [cd_office_coll_cmn_cnty] INT           NOT NULL,
    [tx_office_coll_cmn_cnty] VARCHAR (255) NULL,
    [cd_region]               INT           NULL,
    [tx_region]               VARCHAR (255) NULL,
    [cd_office_county_grp]    INT           NULL,
    [tx_office_county_grp]    VARCHAR (200) NULL,
    [old_region_cd]           INT           NULL
);


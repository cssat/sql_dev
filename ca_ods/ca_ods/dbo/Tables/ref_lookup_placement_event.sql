CREATE TABLE [dbo].[ref_lookup_placement_event] (
    [id_plcmnt_evnt]      INT           NOT NULL,
    [cd_plcmnt_evnt]      CHAR (3)      NOT NULL,
    [cd_plcmnt_evnt_desc] VARCHAR (200) NULL,
    [cd_plcm_setng]       INT           NULL
);


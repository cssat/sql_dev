CREATE FUNCTION [dbo].[DistanceInMiles]
(@LatA             FLOAT = NULL,
@LongA           FLOAT = NULL,
@LatB FLOAT = NULL,
@LongB           FLOAT = NULL
)
RETURNS DECIMAL(9,1)
AS
BEGIN

DECLARE @Distance FLOAT
DECLARE @DeltaLat float = @latB-@latA
declare @DeltaLong float = @longA-@longB
-- use haversine formula , then convert KM to miles
SET @Distance = .6214 * (2* 6371.2 * ASIN(SQRT(SIN(RADIANS(@DeltaLat/2)) * SIN(RADIANS(@DeltaLat/2))  +
					COS(RADIANS(@LatA)) * COS(RADIANS(@LatB)) * SIN(RADIANS(@DeltaLong/2)) * SIN(RADIANS(@DeltaLong/2)))))




RETURN @Distance

END

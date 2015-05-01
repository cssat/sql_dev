CREATE TABLE [ospi].[enrollmentstatus] (
    [int_EnrollmentStatus] INT       IDENTITY (1, 1) NOT NULL,
    [EnrollmentStatus]     CHAR (2)  NOT NULL,
    [EnrollmentStatusDesc] CHAR (80) NULL,
    CONSTRAINT [pk_int_enrollmentStatus] PRIMARY KEY CLUSTERED ([int_EnrollmentStatus] ASC, [EnrollmentStatus] ASC)
);


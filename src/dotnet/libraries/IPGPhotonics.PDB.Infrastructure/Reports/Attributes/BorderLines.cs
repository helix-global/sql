using System;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [Flags]
    [TypeConverter(typeof(SqlEnumConverter<BorderLines>))]
    public enum BorderLines
        {
        None = 0,
        Left = 1,
        Right = 2,
        Top = 4,
        Bottom = 8,
        All = 0xF
        }
    }
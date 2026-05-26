using System;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [Flags]
    [TypeConverter(typeof(SqlEnumConverter<Restrictions>))]
    public enum Restrictions
        {
        None = 0,
        DontMove = 1,
        DontResize = 2,
        DontModify = 4,
        DontEdit = 8,
        DontDelete = 0x10,
        HideAllProperties = 0x20
        }
    }
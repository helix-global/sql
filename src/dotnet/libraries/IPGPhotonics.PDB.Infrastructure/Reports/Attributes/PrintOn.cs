using System;
using System.ComponentModel;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [Flags]
    [TypeConverter(typeof(SqlEnumConverter<PrintOn>))]
    public enum PrintOn
        {
        None = 0,
        FirstPage = 1,
        LastPage = 2,
        OddPages = 4,
        EvenPages = 8,
        RepeatedBand = 0x10,
        SinglePage = 0x20
        }
    }
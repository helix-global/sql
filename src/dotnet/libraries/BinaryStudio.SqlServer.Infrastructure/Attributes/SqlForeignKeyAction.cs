using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [TypeConverter(typeof(SqlForeignKeyActionConverter))]
    public enum SqlForeignKeyAction
        {
        NoAction,
        Cascade,
        SetNull,
        SetDefault
        }
    }

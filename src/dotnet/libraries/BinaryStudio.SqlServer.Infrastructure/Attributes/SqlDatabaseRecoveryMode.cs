using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [TypeConverter(typeof(SqlDatabaseRecoveryModeConverter))]
    public enum SqlDatabaseRecoveryMode
        {
        Unknown,
        Simple,
        BulkLogged,
        Full
        }
    }

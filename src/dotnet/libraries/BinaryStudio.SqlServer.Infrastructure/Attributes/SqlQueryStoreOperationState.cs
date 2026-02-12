using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [TypeConverter(typeof(SqlQueryStoreOperationStateConverter))]
    public enum SqlQueryStoreOperationState
        {
        Off,
        ReadOnly,
        ReadWrite
        }
    }

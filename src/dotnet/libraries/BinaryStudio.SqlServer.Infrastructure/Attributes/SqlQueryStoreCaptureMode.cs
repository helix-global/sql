using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [TypeConverter(typeof(SqlQueryStoreCaptureModeConverter))]
    public enum SqlQueryStoreCaptureMode
        {
        All = 1,
        Auto,
        None
        }
    }

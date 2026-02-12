using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [TypeConverter(typeof(SqlLockEscalationMethodConverter))]
    public enum SqlLockEscalationMethod
        {
        Table,
        Disable,
        Auto
        }
    }

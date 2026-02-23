using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal interface ISqlValueTypeConverter<T>
        where T: struct
        {
        T? ConvertFromObject(Object value);
        T  ConvertFromObject(Object value,T defaultvalue);
        }
    }

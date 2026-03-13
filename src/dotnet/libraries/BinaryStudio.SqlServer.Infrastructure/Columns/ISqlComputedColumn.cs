using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public interface ISqlComputedColumn
        {
        String Expression { get; }
        }
    }
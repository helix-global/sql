using System;
using System.Collections.Generic;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public interface ISqlColumn
        {
        SqlIdentifier Name { get; }
        Boolean IsComputed { get; }
        ISqlTypeSpecifier TypeSpecifier { get; }
        IList<ISqlConstraint> Constraints { get; }
        }
    }
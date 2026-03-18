using System;
using System.Collections.Generic;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public interface ISqlColumn
        {
        SqlObjectIdentifier QualifiedName { get; }
        SqlIdentifier Name { get; }
        Boolean IsComputed { get; }
        ISqlTypeSpecifier TypeSpecifier { get; }
        IList<ISqlConstraint> Constraints { get; }
        String Description { get;set; }
        }
    }
using System;
using System.Collections.Generic;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public interface ISqlIndex
        {
        SqlObjectIdentifier QualifiedName { get; }
        SqlObjectIdentifier TargetObject { get; }
        SqlIdentifier Name { get; }
        Boolean IsUnique { get; }
        SqlClusterOption ClusterOption { get; }
        IList<SqlIdentifier> IncludedColumns { get; }
        IList<ISqlIndexOption> Options { get; }
        IList<ISqlIndexedColumn> IndexedColumns { get; }
        String FilterExpression { get; }
        }
    }
using System.Collections.Generic;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal interface ISqlScriptUniqueConstraint : ISqlConstraint
        {
        SqlClusterOption ClusterOption { get; }
        IList<ISqlIndexOption> IndexOptions { get; }
        IList<ISqlIndexedColumn> IndexedColumns { get; }
        }
    }
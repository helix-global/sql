using System.Collections.Generic;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal interface ISqlScriptUniqueConstraint
        {
        SqlClusterOption ClusterOption { get; }
        IList<ISqlScriptIndexOption> IndexOptions { get; }
        IList<ISqlScriptIndexedColumn> IndexedColumns { get; }
        }
    }
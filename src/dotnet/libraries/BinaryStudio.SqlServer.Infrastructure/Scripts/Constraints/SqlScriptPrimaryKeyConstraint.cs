using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [UsedImplicitly]
    [SqlScriptObject(typeof(SqlPrimaryKeyConstraint))]
    internal sealed class SqlScriptPrimaryKeyConstraint : SqlScriptUniqueConstraint<SqlPrimaryKeyConstraint>
        {
        [UsedImplicitly][Field] public override SqlClusterOption ClusterOption { get; }

        #region ctor{IServiceProvider,SqlPrimaryKeyConstraint}
        public SqlScriptPrimaryKeyConstraint(IServiceProvider context,SqlPrimaryKeyConstraint source)
            : base(context, source)
            {
            if (ClusterOption == SqlClusterOption.Default) {
                ClusterOption = SqlClusterOption.Clustered;
                }
            }
        #endregion
        }
    }
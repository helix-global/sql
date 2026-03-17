using System;
using System.Collections.Generic;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptUniqueConstraint<T> : SqlScriptConstraint<T>,ISqlScriptUniqueConstraint
        where T : SqlUniqueConstraintBase
        {
        [UsedImplicitly][Field] public SqlClusterOption ClusterOption { get; }
        [UsedImplicitly][Field] public IList<ISqlScriptIndexedColumn> IndexedColumns { get; }
        [UsedImplicitly][Field(EmptyIfNull = true)] public IList<ISqlIndexOption> IndexOptions { get; }

        #region ctor{IServiceProvider,T}
        protected SqlScriptUniqueConstraint(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }

    [SqlScriptObject(typeof(SqlUniqueConstraint))]
    internal sealed class SqlScriptUniqueConstraint : SqlScriptUniqueConstraint<SqlUniqueConstraint>
        {
        #region ctor{IServiceProvider,SqlUniqueConstraint}
        public SqlScriptUniqueConstraint(IServiceProvider context,SqlUniqueConstraint source)
            : base(context,source)
            {
            return;
            }
        #endregion
        }
    }
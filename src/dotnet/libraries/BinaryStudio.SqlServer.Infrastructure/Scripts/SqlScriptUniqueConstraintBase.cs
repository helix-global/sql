using System;
using System.Collections.Generic;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptUniqueConstraintBase<T> : SqlScriptConstraint<T>,ISqlScriptUniqueConstraint
        where T : SqlUniqueConstraintBase
        {
        [UsedImplicitly][Field] public SqlClusterOption ClusterOption { get; }
        [UsedImplicitly][Field] public IList<ISqlScriptIndexedColumn> IndexedColumns { get; }
        [UsedImplicitly][Field(EmptyIfNull = true)] public IList<ISqlScriptIndexOption> IndexOptions { get; }

        #region ctor{IServiceProvider,T}
        protected SqlScriptUniqueConstraintBase(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
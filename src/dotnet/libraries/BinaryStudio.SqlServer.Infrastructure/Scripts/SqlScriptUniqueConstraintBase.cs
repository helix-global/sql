using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;
using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptUniqueConstraintBase<T> : SqlScriptConstraint<T>
        where T : SqlUniqueConstraintBase
        {
        [SqlModelFieldMapping][UsedImplicitly] public SqlClusterOption ClusterOption { get; }

        #region ctor{IServiceProvider,T}
        protected SqlScriptUniqueConstraintBase(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptUniqueConstraintBase<T> : SqlScriptConstraint<T>
        where T : SqlUniqueConstraintBase
        {
        public SqlClusterOption ClusterOption {get{ return Source.ClusterOption; }}

        #region ctor{IServiceProvider,T}
        protected SqlScriptUniqueConstraintBase(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
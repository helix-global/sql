using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlEdgeConstraint))]
    internal sealed class SqlScriptEdgeConstraint : SqlScriptConstraint<SqlEdgeConstraint>
        {
        #region ctor{IServiceProvider,SqlDefaultConstraint}
        public SqlScriptEdgeConstraint(IServiceProvider context,SqlEdgeConstraint source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
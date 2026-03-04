using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlDefaultConstraint))]
    internal sealed class SqlScriptDefaultConstraint : SqlScriptConstraint<SqlDefaultConstraint>
        {
        #region ctor{IServiceProvider,SqlDefaultConstraint}
        public SqlScriptDefaultConstraint(IServiceProvider context,SqlDefaultConstraint source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
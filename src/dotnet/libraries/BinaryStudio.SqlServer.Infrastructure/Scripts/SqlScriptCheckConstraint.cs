using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlCheckConstraint))]
    internal sealed class SqlScriptCheckConstraint : SqlScriptConstraint<SqlCheckConstraint>
        {
        #region ctor{IServiceProvider,SqlCheckConstraint}
        public SqlScriptCheckConstraint(IServiceProvider context,SqlCheckConstraint source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
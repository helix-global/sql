using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptForeignKeyConstraint : SqlScriptConstraint<SqlForeignKeyConstraint>
        {
        #region ctor{IServiceProvider,SqlForeignKeyConstraint}
        public SqlScriptForeignKeyConstraint(IServiceProvider context,SqlForeignKeyConstraint source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
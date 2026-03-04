using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptAlterLoginStatement : SqlScriptDdlStatement<SqlAlterLoginStatement>
        {
        #region ctor{IServiceProvider,SqlAlterLoginStatement}
        public SqlScriptAlterLoginStatement(IServiceProvider context,SqlAlterLoginStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
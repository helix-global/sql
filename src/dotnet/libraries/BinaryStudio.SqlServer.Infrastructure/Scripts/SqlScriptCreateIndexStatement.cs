using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptCreateIndexStatement : SqlScriptDdlStatement<SqlCreateIndexStatement>
        {
        #region ctor{IServiceProvider,SqlCreateIndexStatement}
        public SqlScriptCreateIndexStatement(IServiceProvider context,SqlCreateIndexStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
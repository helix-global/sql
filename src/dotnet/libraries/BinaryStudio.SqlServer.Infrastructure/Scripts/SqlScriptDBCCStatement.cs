using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptDBCCStatement : SqlScriptStatement<SqlDBCCStatement>
        {
        public SqlDbccCommandType CommandType {get { return Source.CommandType; }}

        #region ctor{IServiceProvider,SqlDBCCStatement}
        public SqlScriptDBCCStatement(IServiceProvider context,SqlDBCCStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
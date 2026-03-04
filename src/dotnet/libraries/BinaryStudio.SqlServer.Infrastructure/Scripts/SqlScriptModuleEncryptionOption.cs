using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlModuleEncryptionOption))]
    internal sealed class SqlScriptModuleEncryptionOption : SqlScriptModuleOption<SqlModuleEncryptionOption>
        {
        #region ctor{IServiceProvider,SqlModuleEncryptionOption}
        public SqlScriptModuleEncryptionOption(IServiceProvider context,SqlModuleEncryptionOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
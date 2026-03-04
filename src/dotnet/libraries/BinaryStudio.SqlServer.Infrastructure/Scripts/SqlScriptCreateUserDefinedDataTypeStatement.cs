using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptCreateUserDefinedDataTypeStatement : SqlScriptCreateTypeStatement<SqlCreateUserDefinedDataTypeStatement>
        {
        #region ctor{IServiceProvider,SqlCreateUserDefinedDataTypeStatement}
        public SqlScriptCreateUserDefinedDataTypeStatement(IServiceProvider context,SqlCreateUserDefinedDataTypeStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
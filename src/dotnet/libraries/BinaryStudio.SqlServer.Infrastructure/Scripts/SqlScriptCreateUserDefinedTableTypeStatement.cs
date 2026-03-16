using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlCreateUserDefinedTableTypeStatement))]
    internal sealed class SqlScriptCreateUserDefinedTableTypeStatement : SqlScriptCreateTypeStatement<SqlCreateUserDefinedTableTypeStatement>
        {
        #region ctor{IServiceProvider,SqlCreateUserDefinedTableTypeStatement}
        public SqlScriptCreateUserDefinedTableTypeStatement(IServiceProvider context,SqlCreateUserDefinedTableTypeStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
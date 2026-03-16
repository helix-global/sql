using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlCreateUserFromAsymKeyStatement))]
    internal sealed class SqlScriptCreateUserFromAsymKeyStatement : SqlScriptCreateUserStatement<SqlCreateUserFromAsymKeyStatement>
        {
        #region ctor{IServiceProvider,SqlCreateUserFromAsymKeyStatement}
        public SqlScriptCreateUserFromAsymKeyStatement(IServiceProvider context,SqlCreateUserFromAsymKeyStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
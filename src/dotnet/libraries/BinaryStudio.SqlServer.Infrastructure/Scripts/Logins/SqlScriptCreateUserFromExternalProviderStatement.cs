using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlCreateUserFromExternalProviderStatement))]
    internal sealed class SqlScriptCreateUserFromExternalProviderStatement : SqlScriptCreateUserStatement<SqlCreateUserFromExternalProviderStatement>
        {
        #region ctor{IServiceProvider,SqlCreateUserFromExternalProviderStatement}
        public SqlScriptCreateUserFromExternalProviderStatement(IServiceProvider context,SqlCreateUserFromExternalProviderStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
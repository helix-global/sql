using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlCreateLoginWithPasswordStatement))]
    internal sealed class SqlScriptCreateLoginWithPasswordStatement : SqlScriptCreateLoginStatement<SqlCreateLoginWithPasswordStatement>
        {
        #region ctor{IServiceProvider,SqlCreateLoginWithPasswordStatement}
        public SqlScriptCreateLoginWithPasswordStatement(IServiceProvider context,SqlCreateLoginWithPasswordStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }
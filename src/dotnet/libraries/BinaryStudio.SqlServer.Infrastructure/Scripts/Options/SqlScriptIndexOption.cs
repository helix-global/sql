using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptIndexOption<T> : SqlScriptCodeObject<T>,ISqlIndexOption
        where T : SqlIndexOption
        {
        [UsedImplicitly][Field] public String Phrase { get; }
        public abstract SqlIndexOptionType Type { get; }

        #region ctor{IServiceProvider,T}
        protected SqlScriptIndexOption(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion

        #region M:ToString:String
        public override String ToString()
            {
            return $"{Phrase.ToLowerInvariant()}";
            }
        #endregion
        #region M:FormatInline(ISqlObjectFormatter<ISqlIndexOption>):String
        public virtual String FormatInline(ISqlObjectFormatter<ISqlIndexOption> formatter)
            {
            formatter.WriteTo(Context,this,out var r);
            return r;
            }
        #endregion
        }
    }